# Script

## Tell what I am going to do

- lift & shift
  - universal - applicable to any legacy XP
  - challenges
  - why local

## Fixes before go

- duplicate UID
- resolved: Navigation links (datasource children resolver)
-  restore DB, check for PageHeaderMediaCarousel GQL rendering
-  copy metadata ?? {425DF582-C8D5-4EBA-B23E-FA1A069435DD}
-  red boxes: PageHeaderMediaCarousel & LatestNews

## Prerequisites

- vanilla next.js starterkit
- created a tenant and a site
- old site running in VM
  - mapped hostnames
    - access to XP
    - published site
    - diagostics package (to create)

## Database / Content Migration

- How to connect
- Show content migration
  - tell what we should migrate
  - demo migration
    - with tool (homepage & site definition and talk through)
    - with SPE (placeholders)
    - with transformation
      - why? mismatch: dictionaries
      - run demo and show code while copies
    - validating
    -

## Presentation

- Layout
  - deaults xmc and 3 names
  - explain placeholders
  - run from a package
    - `C:\Users\martin\Downloads\Zont Habitat Layout-1.zip`
    - talk and show

  
- Renderings
    - talk through
      - pages copied with the old layout: need to rebind
    - run script

- Rebind presentation
  - difference between XP and XMC

 - set datasources to old definition item (red blocks)
   - item's ID did not change




- Set-DatasourceField.ps1 (for 3 renderings)
- Manually set resolvers to 4 renderings
- set graphql queries Set-FieldValue-FromFile