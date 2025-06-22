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
              <h4 className="panel-title">
                  <a role="button" href="#referralPanel" data-toggle="collapse" className="panel-title collapsed" data-parent="#experiencedata">
                      <span className="fa fa-bullhorn"></span>
                      Referral
                      <span className="glyphicon glyphicon-chevron-down pull-right"></span>
                  </a>
              </h4>
          </div>
          <div id="referralPanel" className="panel-collapse collapse" role="tabpanel">
              <div className="panel-body">
                  <div className="media">
                      <div className="media-left">
                          <span className="fa fa-sign-in"></span>
                      </div>
                      <div className="media-body ">
                          <h4 className="media-title">
                              Referrer
                          </h4>
                              <div className="text-nowrap" title="Direct traffic">
                                  Direct traffic
                              </div>
                      </div>
                  </div>
                  <div className="media">
                      <div className="media-left">
                          <span className="fa fa-bullhorn"></span>
                      </div>
                      <div className="media-body ">
                          <h4 className="media-title">
                              Campaigns
                          </h4>
                              <div className="alert alert-info small">
                                  You have not been associated with any campaigns
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
