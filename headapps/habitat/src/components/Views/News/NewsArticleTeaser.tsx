import { ComponentParams, ComponentRendering } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const NewsArticleTeaser = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>News Article Teaser</h3>

      <div className="thumbnail  m-b-1">
        <header className="thumbnail-header">
          <span className="label">September 24, 2015</span>
          <h3>Sitecore XP rated Best In Class - again</h3>
        </header>
        <div>
          <a href="http://habitat.dev.local/en/Modules/Feature/News/News/2015/08/24/17/57/Best-In-Class">
            <img
              src="/-/media/Habitat/Images/Square/Habitat-075-square.jpg?h=750&amp;mw=750&amp;w=750&amp;hash=7E4F27644180BCE33C63465B59142236"
              className="img-responsive"
              alt="178"
              width="750"
              height="750"
              DisableWebEdit="False"
            />
          </a>
        </div>
        <div className="caption">
          <p>
            <p>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ultricies lectus non
              consectetur suscipit. Nam sed hendrerit sapien, et imperdiet arcu. Proin ac bibendum
              massa. Nam facilisis iaculis egestas.
            </p>
            <p>
              Vestibulum dui nulla, pretium sed sapien vel, pharetra varius odio. Ut vel lacus
              velit. Nulla suscipit eu quam nec faucibus.
            </p>
          </p>
          <a
            href="http://habitat.dev.local/en/Modules/Feature/News/News/2015/08/24/17/57/Best-In-Class"
            className="btn btn-default"
          >
            Read more
          </a>
        </div>
      </div>
    </>
  );
};

export default NewsArticleTeaser;
