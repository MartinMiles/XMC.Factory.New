import React from 'react';
import Link from 'next/link';

type ParentItem = {
  displayName: string;
  url: {
    path: string;
  };
};

interface Fields {
  data: {
    datasource: {
      ancestors: ParentItem[];
      displayName: string;
      title: {
        value: string;
      };
      url: {
        path: string;
      };
    };
  };
}

type BreadcrumbProps = {
  fields: Fields;
};

type AncestorProps = {
  name: string;
  itemurl: string;
  key: string;
};

const ParentLinks = (props: AncestorProps) => {
  return (
    <li>
      <div className="field-link">
        <Link href={props.itemurl}>{props.name}</Link>
      </div>
    </li>
  );
};

export const Default = (props: BreadcrumbProps): JSX.Element => {
  const datasource = props.fields?.data?.datasource;

  if (datasource) {
    const list = datasource.ancestors
      .reverse()
      .filter((element: ParentItem) => element.displayName)
      .map((element: ParentItem, key: number) => (
        <ParentLinks
          name={element.displayName}
          itemurl={element.url.path}
          key={`${key}${element.url}`}
        />
      ));
    return (
      <div className="container">
        <h3 style={{ color: 'red' }}>Breadcrumb</h3>
        <ol className="breadcrumb breadcrumb-1">
          {list}
          <li>
            <Link key={datasource.displayName} href={datasource?.url.path}>
              {datasource?.title?.value || datasource.displayName}
            </Link>
          </li>
        </ol>
      </div>
    );
  }
  return <h3>No Results</h3>;
};
