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

const HeaderTopbar = (props: ComponentProps): JSX.Element => {
  return (
    <>
    <h2>Headless Topbar</h2>
      <div className="header-top">
        <div className="container">
          <div className="row">
            <div className="col-md-6 hidden-xs">
              <Placeholder name="left-header-top" rendering={props.rendering} />
            </div>
            <div className="col-md-6 hidden-xs">
              <div className="pull-right">
                <Placeholder name="right-header-top" rendering={props.rendering} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default HeaderTopbar;
