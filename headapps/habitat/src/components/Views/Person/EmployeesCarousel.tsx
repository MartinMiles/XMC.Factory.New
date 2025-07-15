import { ComponentParams, ComponentRendering } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const EmployeesCarousel = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Employees Carousel</h3>

      <div
        className="owl-carousel"
        data-options='{"items": 3, "navigation": false, "navigationText": ["<", ">"], "autoPlay": true }'
      >
        <div className="mosaic mosaic-bar-bottom mosaic-overlay-show">
          <div className="mosaic-overlay">
            <label>CTO</label>
            <h4>John Howard</h4>
            <div className="btn-group-xs">
              <a
                href="/Modules/Feature/Person/Employees-List/John-Howard"
                className="btn btn-default text-uppercase"
              >
                Read more
              </a>
            </div>
          </div>
          <div className="mosaic-backdrop">
            <a href="/Modules/Feature/Person/Employees-List/John-Howard">
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
        <div className="mosaic mosaic-bar-bottom mosaic-overlay-show">
          <div className="mosaic-overlay">
            <label>CEO</label>
            <h4>John Doe</h4>
            <div className="btn-group-xs">
              <a
                href="/Modules/Feature/Person/Employees-List/John-Doe"
                className="btn btn-default text-uppercase"
              >
                Read more
              </a>
            </div>
          </div>
          <div className="mosaic-backdrop">
            <a href="/Modules/Feature/Person/Employees-List/John-Doe">
              <img
                src="/-/media/Habitat/Images/Square/Habitat-075-square.jpg?h=750&amp;mw=750&amp;w=750&amp;hash=7E4F27644180BCE33C63465B59142236"
                className="img-responsive"
                alt=""
                width="750"
                height="750"
                DisableWebEdit="False"
              />
            </a>
          </div>
        </div>
      </div>
    </>
  );
};

export default EmployeesCarousel;
