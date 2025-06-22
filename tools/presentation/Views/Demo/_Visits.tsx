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
      
    </>
  );
};

export default xDBPanel;
