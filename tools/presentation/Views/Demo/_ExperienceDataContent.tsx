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

const xDBPanel = (props: ComponentProps): JSX.Element => {
  return (
    <>
      
      <div className="panel-group" id="experiencedata">
              <div className="panel panel-warning">
                  <div className="panel-heading">
                      <h3 className="panel-title">
                          <span className="fa fa-warning"></span>
                          Tracking is not active!
                      </h3>
                  </div>
              </div>
          
      <Placeholder name="page-sidebar" rendering={props.rendering} />
      
      </div>
      
      
    </>
  );
};

export default xDBPanel;
