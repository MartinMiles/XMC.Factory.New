import { RichText } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface Fields {
  HTMLContent: {
    value: string;
  };
}

type DemoContentProps = {
  params: { [key: string]: string };
  fields: Fields;
};

const DemoContent = (props: DemoContentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Demo</h3>

      <div className="headline">
        <h2 className="text-center">
          <RichText field={props.fields.HTMLContent} />
          This box can contain any HTML. <br />
          Use the "Edit item" button in the page editor to edit the raw HTML content.
        </h2>
      </div>
    </>
  );
};

export default DemoContent;
