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

const PageTeaser = (props: ComponentProps): JSX.Element => {
  return (
    <>
      
      
      <div className="thumbnail">
        <a href="http://habitat.dev.local/en/About-Habitat/Getting-Started">
          <img src="/-/media/Habitat/Images/Square/Habitat-022-square.jpg?h=500&amp;mw=500&amp;w=500&amp;hash=FF6CADD12E5A79A37835E89D88B034A5" className="img-responsive" alt="" width="500" height="500" DisableWebEdit="False" />
        </a>
        <div className="caption">
          <h3 className="teaser-heading">
            Getting Started
          </h3>
          <p>
            <p>Sitecore Helix a defined methodology with conventions and practises - Habitat is an example implementation available for your understanding.</p>
          </p>
          <a href="http://habitat.dev.local/en/About-Habitat/Getting-Started" className="btn btn-default">
                  Read more
          </a>
        </div>
      </div>
      
    </>
  );
};

export default PageTeaser;
