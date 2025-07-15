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

const Inner2Column66 = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Inner 2 Column 6-6</h3>

      <div className="row">
        <div className="col-sm-6">
          <Placeholder name="col-wide-1" rendering={props.rendering} />
        </div>
        <div className="col-sm-6">
          <Placeholder name="col-wide-2" rendering={props.rendering} />
        </div>
      </div>
    </>
  );
};

export default Inner2Column66;
