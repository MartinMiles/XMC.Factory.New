import { useSitecoreContext, RichText } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface PageBodyProps {
  params: { [key: string]: string };
  fields: {
    Body: { value: string };
  };
}

const PageBody = (props: PageBodyProps): JSX.Element => {
  const { sitecoreContext } = useSitecoreContext();
  const bodyField = props?.fields?.Body || sitecoreContext?.route?.fields?.Body;

  return (
    <>
      <h3 style={{ color: 'red' }}>Page Body</h3>
      <div className="m-b-2">
        <RichText field={bodyField} />
      </div>
    </>
  );
};

export default PageBody;
