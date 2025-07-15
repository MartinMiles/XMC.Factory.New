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

const TwoColumn39 = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Two Column 3-9</h3>

      <div className="@Model.Rendering.GetContainerClass()">
        <div className="row">
          <div className="col-md-3">
            <Placeholder name="col-narrow-1" rendering={props.rendering} />
          </div>
          <div className="col-md-9">
            <Placeholder name="col-wide-1" rendering={props.rendering} />
          </div>
        </div>
      </div>
    </>
  );
};

export default TwoColumn39;
