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
      
      <div className="off-canvas-sidebar off-canvas-sidebar-right">
          <div className="btn-group-vertical hover" role="group">
              <button type="button" className="btn btn-info sidebar-closed" data-toggle="sidebar" title="Open visit details panel" data-side="right">
                  <span className="glyphicon glyphicon-info-sign icon-md "></span>
              </button>
              <button type="button" className="btn btn-info btn-lg sidebar-opened" style="display: none" data-toggle="sidebar" title="Close visit details panel" data-side="right">
                  <span className="glyphicon glyphicon-remove"></span>
                  <span className="hover-only">Close</span>
              </button>
              <button href="#" style="display: none" className="btn btn-success refresh-sidebar sidebar-opened" title="Refresh visit details panel">
                  <span className="glyphicon glyphicon-refresh"></span>
                  <span className="hover-only">Refresh</span>
              </button>
              <button href="#" className="btn btn-danger end-visit sidebar-opened" style="display: none" title="End the current visit and submit it to the Sitecore Experience Database">
                  <span className="glyphicon glyphicon-eye-close"></span>
                  <span className="hover-only">End Visit</span>
              </button>
          </div>
      
          <div className="sidebar sidebar-fixed-right">
              
      
      <div className="panel-group" id="experiencedata">
              <div className="panel panel-warning">
                  <div className="panel-heading">
                      <h3 className="panel-title">
                          <span className="fa fa-warning"></span>
                          Tracking is not active!
                      </h3>
                  </div>
              </div>
          
      
      <div className="panel panel-primary">
        <div className="panel-heading" role="tab">
          <h3 className="panel-title">
            <a role="button" href="#visitsPanel" data-toggle="collapse" className="panel-title collapsed" data-parent="#experiencedata">
              <span className="fa fa-heart"></span>
              Engagement
              <span className="badge" title="Engagement value:" data-toggle="tooltip" data-placement="bottom">
                <span className="fa fa-heart"></span>
                0
              </span>
              <span className="badge" title="Pages Viewed" data-toggle="tooltip" data-placement="bottom">
                <span className="fa fa-eye"></span>
                0
              </span>
              <span className="badge" title="Number of Visits" data-toggle="tooltip" data-placement="bottom">
                <span className="fa fa-history"></span>
                1
              </span>
              <span className="glyphicon glyphicon-chevron-down pull-right"></span>
            </a>
          </h3>
        </div>
        <div id="visitsPanel" className="panel-collapse collapse" role="tabpanel">
          <div className="panel-body">
            <div className="media">
              <div className="media-left">
                <span className="fa fa-heart"></span>
              </div>
      
              <div className="media-body ">
                <h4 className="media-title">
                  Engagement value:
                  <strong className="pull-right">0</strong>
                </h4>
              </div>
            </div>
            <div className="media">
              <div className="media-left">
                <span className="fa fa-eye"></span>
              </div>
              <div className="media-body ">
                <h4 className="media-title">
                  Pages seen in this visit:
                  <strong className="pull-right">0</strong>
                </h4>
              </div>
            </div>
            <table className="table table-condensed table-borderless">
            </table>
            <div className="media">
              <div className="media-left">
                <span className="fa fa-history"></span>
              </div>
              <div className="media-body">
                <h4 className="media-title">
                  Visits to the site:
                </h4>
                  <div className="alert alert-info small">
                    This is your first visit to the site.
                  </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      
          
      
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
                                      <dd>Chrome</dd>
                                  </dl>
                              </div>
                          </div>
                      </div>
              </div>
          </div>
      </div>
      
      
          
      
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
      
      
      </div>
      
      
      
          </div>
      </div>
      
    </>
  );
};

export default xDBPanel;
