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
      
      <div className="panel panel-primary">
          <div className="panel-heading" role="tab">
              <h3 className="panel-title">
                  <a role="button" href="#personalInfoPanel" data-toggle="collapse" className="panel-title collapsed" data-parent="#experiencedata">
                      <span className="fa fa-user"></span>
                      Personal Information
                      <span className="glyphicon glyphicon-chevron-down pull-right"></span>
                  </a>
              </h3>
          </div>
          <div id="personalInfoPanel" className="panel-collapse collapse" role="tabpanel">
              <div className="panel-body">
                  <div className="media">
                      <div className="media-left">
                          <span className="fa fa-user"></span>
                      </div>
                      <div className="media-body ">
                          <h4 className="media-title">
      You are anonymous                    </h4>
                          <dl className="small">
                          </dl>
                      </div>
                  </div>
                                  <div className="media">
                          <div className="media-left">
                              <span className="fa fa-tablet"></span>
                          </div>
                          <div className="media-body ">
                              <h4 className="media-title">
                                  Device
                              </h4>
                              <div className="text-nowrap">
                                  <dl>
                                      <dt>Device</dt>
                                      <dd>Unknown, Desktop, Emulator</dd>
                                      <dt>Browser</dt>
                                      <dd>Unknown Windows App - WebKit Engine</dd>
                                  </dl>
                              </div>
                          </div>
                      </div>
              </div>
          </div>
      </div>
      
    </>
  );
};

export default xDBPanel;
