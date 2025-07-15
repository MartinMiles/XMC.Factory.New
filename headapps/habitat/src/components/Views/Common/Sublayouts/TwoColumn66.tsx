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

const TwoColumn66 = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Two Column 6-6</h3>

      <div className="container">
        <div className="row">
          <div className="col-md-6">
            <Placeholder name="col-wide-1" rendering={props.rendering} />
          </div>
          <div className="col-md-6">
            <Placeholder name="col-wide-2" rendering={props.rendering} />
          </div>
        </div>
      </div>
    </>
  );
};

export default TwoColumn66;
