import { Text } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface Fields {
  TeaserTitle: {
    value: string;
  };
}

type HeadlineProps = {
  params: { [key: string]: string };
  fields: Fields;
};

const Headline = (props: HeadlineProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Headline</h3>

      <div className="headline">
        <h2 className="text-center">
          <Text field={props.fields.TeaserTitle} />
        </h2>
      </div>
    </>
  );
};

export default Headline;
