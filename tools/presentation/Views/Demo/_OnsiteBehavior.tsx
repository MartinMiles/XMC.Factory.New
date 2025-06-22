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
                  <a role="button" href="#onsiteBehaviorPanel" data-toggle="collapse" className="panel-title collapsed" data-parent="#experiencedata">
                      <span className="fa fa-bullseye"></span>
                      Onsite Behavior
                      <span className="glyphicon glyphicon-chevron-down pull-right"></span>
                  </a>
              </h4>
          </div>
          <div id="onsiteBehaviorPanel" className="panel-collapse collapse" role="tabpanel">
              <div className="panel-body">
                  <div className="media">
                      <div className="media-left">
                          <span className="fa fa-users"></span>
                      </div>
                      <div className="media-body ">
                          <h4 className="media-title">
                              Profiling
                          </h4>
                          <div className="media-body">
                                  <div className="alert alert-info small">
                                      You have not been profiled yet
                                  </div>
                          </div>
                      </div>
                  </div>
                  <div className="media">
                      <div className="media-left">
                          <span className="fa fa-trophy"></span>
                      </div>
                      <div className="media-body ">
                          <h4 className="media-title">
                              Triggered goals
                          </h4>
                          <div className="media-body">
                              <ul className="nav nav-tabs nav-justified small">
                                  <li className="active">
                                      <a href="#onSiteBehaviorGoals" data-toggle="tab">Goals</a>
                                  </li>
                                  <li>
                                      <a href="#onSiteBehaviorPageEvents" data-toggle="tab">Page Events</a>
                                  </li>
                              </ul>
      
                              <div className="tab-content">
                                  <div role="tabpanel" className="tab-pane active" id="onSiteBehaviorGoals">
                                          <div className="alert alert-info small">
                                              You have triggered no goals so far
                                          </div>
                                  </div>
                                  <div role="tabpanel" className="tab-pane" id="onSiteBehaviorPageEvents">
                                          <div className="alert alert-info small">
                                              You have triggered no page events so far
                                          </div>
                                  </div>
                              </div>
                          </div>
                      </div>
                  </div>
                  <div className="media">
                      <div className="media-left">
                          <span className="fa fa-money"></span>
                      </div>
                      <div className="media-body ">
                          <h4 className="media-title">
                              Outcomes
                          </h4>
                              <div className="alert alert-info small">
                                  You have reached no outcomes
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
