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

const ThreeColumn633 = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Three Column 6-3-3</h3>
      <div className="container">
        <div className="row">
          <div className="col-lg-6 col-md-12">
            <Placeholder name="col-wide-1" rendering={props.rendering} />
          </div>
          <div className="col-lg-3 col-sm-6">
            <Placeholder name="col-narrow-1" rendering={props.rendering} />
          </div>
          <div className="col-lg-3 col-sm-6">
            <Placeholder name="col-narrow-2" rendering={props.rendering} />
          </div>
        </div>
      </div>
    </>
  );
};

export default ThreeColumn633;
