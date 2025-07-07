import { RichText } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface Fields {
  Copyright: {
    value: string;
  };
}

type CopyrightProps = {
  params: { [key: string]: string };
  fields: Fields;
};

const Copyright = (props: CopyrightProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Copyright</h3>
      <small className="copyright">
        <RichText field={props.fields.Copyright} />
      </small>
    </>
  );
};

export default Copyright;
