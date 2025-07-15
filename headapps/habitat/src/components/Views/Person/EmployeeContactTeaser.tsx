import { ComponentParams, ComponentRendering } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const EmployeeContactTeaser = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Employee Contact Teaser</h3>

      <aside className="">
        <div className="mosaic mosaic-bar-bottom mosaic-overlay-show">
          <div className="mosaic-overlay">
            <label>CEO</label>
            <h4>John Doe</h4>
          </div>
          <div className="mosaic-backdrop">
            <a href="http://habitat.dev.local/en/Modules/Feature/Person/Employees-List/John-Doe">
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

        <div className="caption text-center">
          <ul className="list list-unstyled">
            <li>
              <a href="tel:+1 202 555 0162" className="btn btn-link" role="button">
                <span className="fa fa-phone fa-lg"></span> +1 202 555 0162
              </a>
            </li>
            <li>
              <a href="tel:+1 202 555 0148" className="btn btn-link" role="button">
                <span className="fa fa-mobile fa-lg"></span> +1 202 555 0148
              </a>
            </li>
            <li>
              <a href="mailto:john.doe@sitecorehabitat.com" className="btn btn-link" role="button">
                <span className="fa fa-envelope fa-lg"></span> john.doe@sitecorehabitat.com
              </a>
            </li>
          </ul>
          <div>
            <span className="btn-group">
              <a href="http://MyBlog.com" target="_blank" className="btn btn-info">
                <i className="fa fa-globe"></i>
              </a>
              <a
                href="http://twitter.com"
                target="_blank"
                className="btn btn-social-icon btn-twitter"
              >
                <i className="fa fa-twitter"></i>
              </a>
              <a
                href="www.facebook.com"
                target="_blank"
                className="btn btn-social-icon btn-facebook"
              >
                <i className="fa fa-facebook"></i>
              </a>
              <a
                href="http://linkedin.com"
                target="_blank"
                className="btn btn-social-icon btn-linkedin"
              >
                <i className="fa fa-linkedin"></i>
              </a>
            </span>
            <a
              href="http://habitat.dev.local/en/Modules/Feature/Person/Employees-List/John-Doe"
              className="btn btn-default"
            >
              Read more
            </a>
          </div>
        </div>
      </aside>
    </>
  );
};

export default EmployeeContactTeaser;
