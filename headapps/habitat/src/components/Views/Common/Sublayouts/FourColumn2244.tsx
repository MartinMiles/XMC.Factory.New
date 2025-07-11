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

const FourColumn2244 = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Four Column 2-2-4-4</h3>
      <div className="container">
        <div className="row">
          <div className="col-md-2 col-sm-6">
            <Placeholder name="col-narrow-1" rendering={props.rendering} />
          </div>
          <div className="col-md-2 col-sm-6">
            <Placeholder name="col-narrow-2" rendering={props.rendering} />
          </div>
          <div className="col-md-4 col-sm-6">
            <Placeholder name="col-narrow-3" rendering={props.rendering} />
          </div>
          <div className="col-md-4 col-sm-6">
            <Placeholder name="col-narrow-4" rendering={props.rendering} />
          </div>
        </div>
      </div>
    </>
  );
};

export default FourColumn2244;
