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

const ThreeColumn444 = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Three Column 4-4-4</h3>
      <div className="container">
        <div className="row">
          <div className="col-sm-4">
            <Placeholder name="col-narrow-1" rendering={props.rendering} />
          </div>
          <div className="col-sm-4">
            <Placeholder name="col-narrow-2" rendering={props.rendering} />
          </div>
          <div className="col-sm-4">
            <Placeholder name="col-narrow-3" rendering={props.rendering} />
          </div>
        </div>
      </div>
    </>
  );
};

export default ThreeColumn444;
