import {
  Field,
  ImageField,
  RichText,
  Text,
  useSitecoreContext,
} from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface PageContentHeaderTitleProps {
  params: { [key: string]: string };
  fields: {
    Title: Field<string>;
    Summary: Field<string>;
    Body: Field<string>;
    Image: ImageField;
  };
}

export const Default: React.FC<PageContentHeaderTitleProps> = (props): JSX.Element => {
  const { sitecoreContext } = useSitecoreContext();
  const titleField = props?.fields?.Title || sitecoreContext?.route?.fields?.Title;
  const summaryField = props?.fields?.Summary || sitecoreContext?.route?.fields?.Summary;

  return (
    <>
      <h3 style={{ color: 'red' }}>Page Content Header Title</h3>
      <div className="container m-b-1">
        <h1>
          <Text field={titleField} className="page-title" />
          <br />
          <small>
            <RichText field={summaryField} className="page-title" />
          </small>
        </h1>
      </div>
    </>
  );
};
