import { ComponentParams, ComponentRendering } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const ImageWithLightbox = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Image With Lightbox</h3>

      <div className="thumbnail mosaic mosaic-circle lightbox-item lightbox-image">
        <div className="mosaic-overlay mosaic-overlay-no-pointer">
          <span className="fa fa-search-plus icon-lg"></span>
        </div>
        <div className="mosaic-backdrop">
          <a
            href="/-/media/Habitat/Images/Wide/Habitat-001-wide.jpg?thn=0&amp;w=1200&amp;hash=38108E4DE02B341D0926A9EDF5134671"
            data-type="image"
            data-title="Extensibility"
            data-footer="Add new features, simply and without a steep learning curve"
            data-toggle="lightbox"
            data-gallery="page"
          >
            <img
              src="/-/media/Habitat/Images/Wide/Habitat-001-wide.jpg?h=258&amp;mw=750&amp;w=750&amp;hash=27F06769FB625B63A96722F9FD4399BC"
              className="img-responsive"
              alt="Blonde Woman"
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

export default ImageWithLightbox;
