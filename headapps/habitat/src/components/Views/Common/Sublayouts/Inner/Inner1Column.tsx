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

const Inner1Column = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Inner 1 Column</h3>

      <div className="row">
        <div className="col-md-12">
          <Placeholder name="col-wide-1" rendering={props.rendering} />
        </div>
      </div>
    </>
  );
};

export default Inner1Column;
