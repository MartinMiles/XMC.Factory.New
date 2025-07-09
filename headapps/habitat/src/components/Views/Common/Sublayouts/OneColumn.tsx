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

const OneColumn = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>One Column</h3>
      <div className="container">
        <div className="row">
          <div className="col-md-12">
            <Placeholder name="col-huge" rendering={props.rendering} />
          </div>
        </div>
      </div>
    </>
  );
};

export default OneColumn;
