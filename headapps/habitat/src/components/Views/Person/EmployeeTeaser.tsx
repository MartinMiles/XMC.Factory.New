import { ComponentParams, ComponentRendering } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const EmployeeTeaser = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Employee Teaser</h3>

      <div className="mosaic mosaic-bar-bottom mosaic-overlay-show">
        <div className="mosaic-overlay">
          <label>CTO</label>
          <h4>John Howard</h4>
          <a
            href="http://habitat.dev.local/en/Modules/Feature/Person/Employees-List/John-Howard"
            target="_blank"
            className="btn btn-primary text-uppercase btn-xs"
          >
            Read more
          </a>
        </div>
        <div className="mosaic-backdrop">
          <a href="http://habitat.dev.local/en/Modules/Feature/Person/Employees-List/John-Howard">
            <img
              src="/-/media/Habitat/Images/Square/Habitat-064-square.jpg?h=750&amp;mw=750&amp;w=750&amp;hash=505034E5524B6F7AEA68F2D63A6D143F"
              className="img-responsive"
              alt=""
              width="750"
              height="750"
              DisableWebEdit="False"
            />
          </a>
        </div>
      </div>
    </>
  );
};

export default EmployeeTeaser;
