use [Sitecore.Old]
GO

--------------------------------------------------------------------------------
-- 0) Identify layout‐field IDs
--------------------------------------------------------------------------------
DECLARE 
    @SharedLayoutFieldId UNIQUEIDENTIFIER,
    @FinalLayoutFieldId  UNIQUEIDENTIFIER;

SELECT @SharedLayoutFieldId = ID
  FROM dbo.Items
  WHERE Name = '__Renderings';

SELECT @FinalLayoutFieldId = ID
  FROM dbo.Items
  WHERE Name = '__Final renderings';

IF @SharedLayoutFieldId IS NULL
   OR @FinalLayoutFieldId  IS NULL
BEGIN
    RAISERROR('Missing __Renderings or __Final renderings field.', 16, 1);
    RETURN;
END;

--------------------------------------------------------------------------------
-- 0b) Configure the Datasources root
--------------------------------------------------------------------------------
DECLARE
  @L1 NVARCHAR(200) = 'sitecore',
  @L2 NVARCHAR(200) = 'content',
  @L3 NVARCHAR(200) = 'Habitat',
  @L4 NVARCHAR(200) = 'Settings',
  @L5 NVARCHAR(200) = 'Datasources';

DECLARE @RootPath NVARCHAR(MAX) =
  '/' + @L1 + '/' + @L2 + '/' + @L3 + '/' + @L4 + '/' + @L5;

DECLARE @RootID UNIQUEIDENTIFIER;
SELECT @RootID = dst.ID
FROM dbo.Items AS L1
JOIN dbo.Items AS L2 ON L2.ParentID = L1.ID AND L2.Name = @L2
JOIN dbo.Items AS L3 ON L3.ParentID = L2.ID AND L3.Name = @L3
JOIN dbo.Items AS L4 ON L4.ParentID = L3.ID AND L4.Name = @L4
JOIN dbo.Items AS dst
  ON dst.ParentID = L4.ID AND dst.Name = @L5
WHERE
  L1.ParentID = '00000000-0000-0000-0000-000000000000'
  AND L1.Name     = @L1;

IF @RootID IS NULL
BEGIN
  RAISERROR('Couldn''t find %s',16,1,@RootPath);
  RETURN;
END;

--------------------------------------------------------------------------------
-- 1) All CTEs: Datasources lookup + Rendering metadata
--------------------------------------------------------------------------------
;WITH

-- 1a) Build the Datasources tree under /…/Settings/Datasources
ItemTree AS (
  SELECT
    ID,
    ParentID,
    Name,
    TemplateID,
    @RootPath AS FullPath
  FROM dbo.Items
  WHERE ID = @RootID

  UNION ALL

  SELECT
    i.ID,
    i.ParentID,
    i.Name,
    i.TemplateID,
    t.FullPath + '/' + i.Name
  FROM dbo.Items AS i
  INNER JOIN ItemTree AS t
    ON i.ParentID = t.ID
),

-- 1b) Gather every field value in one place
FieldData AS (
  SELECT ItemID, FieldID, Value FROM dbo.SharedFields
  UNION ALL
  SELECT ItemID, FieldID, Value FROM dbo.UnversionedFields
  UNION ALL
  SELECT ItemID, FieldID, Value FROM dbo.VersionedFields
),

-- 1c) Extract each item's DatasourceLocation
LocValues AS (
  SELECT DISTINCT fd.ItemID, fd.Value
  FROM FieldData AS fd
  JOIN dbo.Items AS fdef
    ON fdef.ID = fd.FieldID
  WHERE fdef.Name = 'DatasourceLocation'
),

-- 1d) Extract each item's DatasourceTemplate
TplValues AS (
  SELECT DISTINCT fd.ItemID, fd.Value
  FROM FieldData AS fd
  JOIN dbo.Items AS fdef
    ON fdef.ID = fd.FieldID
  WHERE fdef.Name = 'DatasourceTemplate'
),

-- 1e) Combine into a lookup CTE
Datasources AS (
  SELECT
    it.Name             AS ItemName,
    it.FullPath         AS ItemPath,
    lv.Value            AS DS_LocationOverride,
    tv.Value            AS DS_TemplateOverride
  FROM ItemTree AS it
  LEFT JOIN LocValues AS lv ON lv.ItemID = it.ID
  LEFT JOIN TplValues AS tv ON tv.ItemID = it.ID
  WHERE it.ID <> @RootID
),

-- 2a) Find every item that has an explicit shared or final layout
PagesWithLayout AS (
  SELECT DISTINCT fld.ItemID AS ItemID
  FROM (
    SELECT ItemID, FieldID FROM dbo.SharedFields
    UNION ALL
    SELECT ItemID, FieldID FROM dbo.UnversionedFields
    UNION ALL
    SELECT ItemID, FieldID FROM dbo.VersionedFields
  ) AS fld
  WHERE fld.FieldID IN (@SharedLayoutFieldId, @FinalLayoutFieldId)
),

-- 2b) Pull the raw layout XML from each template’s __Standard Values
Layouts AS (
  SELECT 
    CAST(SF.Value AS XML) AS LayoutXml
  FROM dbo.SharedFields AS SF
  JOIN dbo.Items AS StdVals
    ON SF.ItemId = StdVals.ID
  JOIN dbo.Items AS PageItem
    ON StdVals.TemplateID = PageItem.TemplateID
  JOIN PagesWithLayout AS pwl
    ON pwl.ItemID = PageItem.ID
  WHERE StdVals.Name = '__Standard Values'
    AND SF.FieldId IN (@SharedLayoutFieldId, @FinalLayoutFieldId)
),

-- 2c) Shred out each <r> node’s @id attribute
Shredded AS (
  SELECT 
    R.value('@id','nvarchar(50)') AS defid_str
  FROM Layouts
  CROSS APPLY LayoutXml.nodes('/r/d/r') AS X(R)
),

-- 2d) Convert to GUIDs
Parsed AS (
  SELECT DISTINCT
    TRY_CONVERT(uniqueidentifier, NULLIF(defid_str, '')) AS RenderingDefinitionId
  FROM Shredded
  WHERE defid_str <> ''
),

-- 2e) Base list of definition IDs
DefinitionItems AS (
  SELECT RenderingDefinitionId AS ID
  FROM Parsed
),

-- 2f) Pull each definition’s Editable / Datasource… / Parameters… fields
DefinitionFieldValues AS (
  SELECT
    DI.ID                             AS RenderingDefinitionId,
    FD.Name                           AS FieldName,
    SF2.Value                         AS FieldValue
  FROM DefinitionItems AS DI
  LEFT JOIN dbo.SharedFields AS SF2
    ON SF2.ItemId = DI.ID
  LEFT JOIN dbo.Items AS FD
    ON FD.ID = SF2.FieldId
   AND FD.Name IN (
     'Editable',
     'Datasource Location',
     'Datasource Template',
     'Parameters Template'
   )
),

-- 2g) Pivot those into columns
DefinitionFieldsPivot AS (
  SELECT
    RenderingDefinitionId,
    MAX(CASE WHEN FieldName = 'Editable'            THEN FieldValue END) AS Editable,
    MAX(CASE WHEN FieldName = 'Datasource Location' THEN FieldValue END) AS DatasourceLocation,
    MAX(CASE WHEN FieldName = 'Datasource Template' THEN FieldValue END) AS DatasourceTemplate,
    MAX(CASE WHEN FieldName = 'Parameters Template' THEN FieldValue END) AS ParametersTemplate
  FROM DefinitionFieldValues
  GROUP BY RenderingDefinitionId
),

-- 2h) Build every ancestor path for each definition item
Paths AS (
  SELECT 
    DI.ID,
    I.Name,
    I.ParentID,
    CAST('/' + I.Name AS NVARCHAR(MAX)) AS FullPath
  FROM DefinitionItems AS DI
  JOIN dbo.Items AS I
    ON I.ID = DI.ID

  UNION ALL

  SELECT
    P.ID,
    Parent.Name,
    Parent.ParentID,
    CAST('/' + Parent.Name + P.FullPath AS NVARCHAR(MAX))
  FROM Paths AS P
  JOIN dbo.Items AS Parent
    ON Parent.ID = P.ParentID
),

-- 2i) Pick the single longest path per definition
DefinitionPaths AS (
  SELECT
    P.ID                                 AS RenderingDefinitionId,
    P.FullPath,
    ROW_NUMBER() OVER (
      PARTITION BY P.ID
      ORDER BY LEN(P.FullPath) DESC
    ) AS rn
  FROM Paths AS P
),

RenderingPaths AS (
  SELECT
    RenderingDefinitionId,
    FullPath AS RenderingPath
  FROM DefinitionPaths
  WHERE rn = 1
)

--------------------------------------------------------------------------------
-- 3) Final SELECT: add NextComponentName (with leading‐digit→word logic), then overrides
--------------------------------------------------------------------------------
SELECT DISTINCT
  Def.Name                                  AS RenderingName,

  -- 3a) Next.js–friendly component name, but if the first token is a digit 0–9, map it to a word
  NC.NextComponentName,

  -- 3b) existing columns
  RP.RenderingPath,
  RP.RenderingDefinitionId,

  -- 3c) override DatasourceLocation if it was 'site:...'
  CASE
    WHEN DFP.DatasourceLocation LIKE 'site:%'
      THEN D.ItemPath
    ELSE DFP.DatasourceLocation
  END AS DatasourceLocation,

  -- 3d) override DatasourceTemplate if it was 'site:%'
  CASE
    WHEN DFP.DatasourceLocation LIKE 'site:%'
      THEN D.DS_TemplateOverride
    ELSE DFP.DatasourceTemplate
  END AS DatasourceTemplate,

  DFP.Editable,
  DFP.ParametersTemplate

FROM RenderingPaths AS RP
JOIN dbo.Items AS Def
  ON Def.ID = RP.RenderingDefinitionId

LEFT JOIN DefinitionFieldsPivot AS DFP
  ON DFP.RenderingDefinitionId = RP.RenderingDefinitionId

LEFT JOIN Datasources AS D
  ON REPLACE(DFP.DatasourceLocation, 'site:', '') = D.ItemName

CROSS APPLY (
  SELECT
    STRING_AGG(
      -- If this is the very first token ([key] = 0) AND it is convertible to an integer between 0 and 9,
      -- map it to its English word; otherwise, just Title-case the token.
      CASE
        WHEN [key] = 0 AND TRY_CONVERT(int, [value]) BETWEEN 0 AND 9 THEN
          CASE TRY_CONVERT(int, [value])
            WHEN 0 THEN 'Zero'
            WHEN 1 THEN 'One'
            WHEN 2 THEN 'Two'
            WHEN 3 THEN 'Three'
            WHEN 4 THEN 'Four'
            WHEN 5 THEN 'Five'
            WHEN 6 THEN 'Six'
            WHEN 7 THEN 'Seven'
            WHEN 8 THEN 'Eight'
            WHEN 9 THEN 'Nine'
            ELSE UPPER(LEFT([value], 1)) + LOWER(SUBSTRING([value], 2, LEN([value])))
          END
        ELSE
          UPPER(LEFT([value], 1)) + LOWER(SUBSTRING([value], 2, LEN([value])))
      END,
      ''  -- concatenate with no separator
    ) WITHIN GROUP (ORDER BY [key]) AS NextComponentName
  FROM OPENJSON(
    '["'
      + REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(Def.Name, '"', ''),  -- strip quotes
                '-', ' '),                   -- hyphens → spaces
              '/', ' '),                    -- slashes → spaces
            ':', ' '),                       -- colons → spaces
          ' ', '","')                       -- spaces → JSON separators
      + '"]'
  )
) AS NC

ORDER BY
  Def.Name,
  RP.RenderingPath;