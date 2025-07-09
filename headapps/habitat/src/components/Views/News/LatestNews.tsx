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

const LatestNews = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Latest News</h3>
      <div className="well ">
        <h5 className="text-uppercase">News</h5>
        <ul className="media-list">
          <li className="media">
            <div className="media-body">
              <date>September 24, 2015</date>
              <h4 className="media-heading">
                <a href="http://habitat.dev.local/en/Modules/Feature/News/News/2015/08/24/17/57/Best-In-Class">
                  Sitecore XP rated Best In Class - again
                </a>
              </h4>
            </div>
          </li>
          <li className="media">
            <div className="media-body">
              <date>August 24, 2015</date>
              <h4 className="media-heading">
                <a href="http://habitat.dev.local/en/Modules/Feature/News/News/2015/08/24/17/57/New-version">
                  Sitecore releases new feature packed version
                </a>
              </h4>
            </div>
          </li>
          <li className="media">
            <div className="media-body">
              <date>August 24, 2015</date>
              <h4 className="media-heading">
                <a href="http://habitat.dev.local/en/Modules/Feature/News/News/2015/08/24/17/57/Experience-Management">
                  New praise for world class experience management platform
                </a>
              </h4>
            </div>
          </li>
        </ul>
        <a href="http://habitat.dev.local/en/Modules/Feature/News/News" className="btn btn-default">
          Read more
        </a>
      </div>
    </>
  );
};

export default LatestNews;
