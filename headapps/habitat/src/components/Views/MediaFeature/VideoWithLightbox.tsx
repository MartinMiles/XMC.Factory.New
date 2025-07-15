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

const VideoWithLightbox = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Video with Lightbox</h3>

      <div className="thumbnail mosaic mosaic-circle lightbox-item lightbox-image">
        <div className="mosaic-overlay mosaic-overlay-no-pointer">
          <span className="fa fa-play-circle icon-lg"></span>
        </div>
        <div className="mosaic-backdrop">
          <a
            href="https://youtu.be/RchuR18xLa0"
            data-type=""
            data-title="Habitat Introduction"
            data-footer="&lt;p&gt;Video introducing the concepts and thoughts behind the Sitecore Helix methodology.&lt;/p&gt;"
            data-toggle="lightbox"
            data-gallery="page"
            data-width="750"
          >
            <img
              src="/-/media/Habitat/Images/Content/Habitat-Introduction-Video.png?h=258&amp;mw=750&amp;w=750&amp;hash=C9D486059C50CA3AA464424EE585262F"
              className="img-responsive"
              alt="Habitat Introduction Video"
              width="750"
              height="258"
              DisableWebEdit="False"
            />
          </a>
        </div>
      </div>
    </>
  );
};

export default VideoWithLightbox;
