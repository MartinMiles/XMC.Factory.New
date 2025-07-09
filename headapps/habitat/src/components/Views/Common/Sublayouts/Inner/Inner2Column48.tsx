import {
  ComponentParams,
  ComponentRendering,
  Placeholder,
} from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const Inner2Column48 = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Inner 2 Column 4-8</h3>
      <div className="row">
        <div className="col-md-4">
          <Placeholder name="col-narrow-1" rendering={props.rendering} />
        </div>
        <div className="col-md-8">
          <Placeholder name="col-wide-1" rendering={props.rendering} />
        </div>
      </div>
    </>
  );
};

export default Inner2Column48;
