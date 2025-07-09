import { useSitecoreContext, Text, RichText } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface PageTitleProps {
  params: { [key: string]: string };
  fields: {
    Title: { value: string };
    Summary: { value: string };
  };
}

const PageTitle = (props: PageTitleProps): JSX.Element => {
  const { sitecoreContext } = useSitecoreContext();
  const titleField = props?.fields?.Title || sitecoreContext?.route?.fields?.Title;
  const summaryField = props?.fields?.Summary || sitecoreContext?.route?.fields?.Summary;

  return (
    <>
      <h3 style={{ color: 'red' }}>Page Title</h3>
      <header>
        <h1>
          <Text field={titleField} />
        </h1>
        <div className="lead">
          <RichText field={summaryField} />
        </div>
      </header>
    </>
  );
};

export default PageTitle;
