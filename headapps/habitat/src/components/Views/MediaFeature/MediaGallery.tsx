import { ComponentParams, ComponentRendering } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const MediaGallery = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Media Gallery</h3>

      <div
        className="block-grid-lg-4 block-grid-md-3 block-grid-sm-2 block-grid-xs-1"
        id="gallery8d9f26098f364c9bbf4aba9e68255f6c"
      >
        <div className="block-grid-item">
          <div className="thumbnail mosaic mosaic-circle lightbox-item lightbox-image">
            <div className="mosaic-overlay mosaic-overlay-no-pointer">
              <span className="fa fa-search-plus icon-lg"></span>
            </div>
            <div className="mosaic-backdrop">
              <a
                href="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-1.png?thn=0&amp;w=1200&amp;hash=11D13C853A03EE22BC70E32F168E94BC"
                data-type="image"
                data-title="Building a Sitecore Solution is Easy!"
                data-footer="&lt;p&gt;Taking the first steps in building a Sitecore solution is often quite rapid. You can be very productive and cover a great deal of functionality in a short sprint&lt;/p&gt;"
                data-toggle="lightbox"
                data-gallery="gallery8d9f26098f364c9bbf4aba9e68255f6c"
              >
                <img
                  src="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-1.png?h=422&amp;mw=750&amp;w=750&amp;hash=DF5E42862CCFE9A5B562377BE1165EB4"
                  className="img-responsive"
                  alt="Dependencies in Habitat"
                  width="750"
                  height="422"
                  DisableWebEdit="False"
                />
              </a>
            </div>
          </div>
        </div>
        <div className="block-grid-item">
          <div className="thumbnail mosaic mosaic-circle lightbox-item lightbox-image">
            <div className="mosaic-overlay mosaic-overlay-no-pointer">
              <span className="fa fa-search-plus icon-lg"></span>
            </div>
            <div className="mosaic-backdrop">
              <a
                href="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-2.png?thn=0&amp;w=1200&amp;hash=097E824387ABE3FF928653F716C4339B"
                data-type="image"
                data-title="Coupling between features and functionality can make life harder."
                data-footer="&lt;p&gt;Once the solution scope is expanding, dependencies and coupling between features and functionalities can make productivity slower.&lt;/p&gt;"
                data-toggle="lightbox"
                data-gallery="gallery8d9f26098f364c9bbf4aba9e68255f6c"
              >
                <img
                  src="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-2.png?h=422&amp;mw=750&amp;w=750&amp;hash=70D6CDAFE9806DF23931F5D1D1B3E6DD"
                  className="img-responsive"
                  alt="Dependencies in Habitat"
                  width="750"
                  height="422"
                  DisableWebEdit="False"
                />
              </a>
            </div>
          </div>
        </div>
        <div className="block-grid-item">
          <div className="thumbnail mosaic mosaic-circle lightbox-item lightbox-image">
            <div className="mosaic-overlay mosaic-overlay-no-pointer">
              <span className="fa fa-search-plus icon-lg"></span>
            </div>
            <div className="mosaic-backdrop">
              <a
                href="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-3.png?thn=0&amp;w=1200&amp;hash=E5C7EEC47D36B984C9444328C0387C47"
                data-type="image"
                data-title="Wrong architecture can grind productivity to a halt."
                data-footer="If dependencies and coupling in not constantly monitored and conventions and principles are kept in place, over time the productivity and thereby long term business value will suffer."
                data-toggle="lightbox"
                data-gallery="gallery8d9f26098f364c9bbf4aba9e68255f6c"
              >
                <img
                  src="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-3.png?h=422&amp;mw=750&amp;w=750&amp;hash=3B820D6BAF409790B0669579BFFD504B"
                  className="img-responsive"
                  alt="Dependencies in Habitat"
                  width="750"
                  height="422"
                  DisableWebEdit="False"
                />
              </a>
            </div>
          </div>
        </div>
        <div className="block-grid-item">
          <div className="thumbnail mosaic mosaic-circle lightbox-item lightbox-image">
            <div className="mosaic-overlay mosaic-overlay-no-pointer">
              <span className="fa fa-search-plus icon-lg"></span>
            </div>
            <div className="mosaic-backdrop">
              <a
                href="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-4.png?thn=0&amp;w=1200&amp;hash=39F52AF323EE739EF2EB08AC0D6A96AB"
                data-type="image"
                data-title="Correct layering and dependency control"
                data-footer="With a layered approach, where dependencies are tightly controlled using technical design principles and patterns. The coupling between modules and functionalities can be reduced significantly."
                data-toggle="lightbox"
                data-gallery="gallery8d9f26098f364c9bbf4aba9e68255f6c"
              >
                <img
                  src="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-4.png?h=422&amp;mw=750&amp;w=750&amp;hash=E67718C3750F7E946E86E4EB80C15C7F"
                  className="img-responsive"
                  alt="Dependencies in Habitat"
                  width="750"
                  height="422"
                  DisableWebEdit="False"
                />
              </a>
            </div>
          </div>
        </div>
        <div className="block-grid-item">
          <div className="thumbnail mosaic mosaic-circle lightbox-item lightbox-image">
            <div className="mosaic-overlay mosaic-overlay-no-pointer">
              <span className="fa fa-search-plus icon-lg"></span>
            </div>
            <div className="mosaic-backdrop">
              <a
                href="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-5.png?thn=0&amp;w=1200&amp;hash=D91946BBD84CBA2B15D3439A744F4082"
                data-type="image"
                data-title="Low coupling means higher productivity"
                data-footer="With fewer dependencies and tighter controlled coupling - both on the micro and macro architecture levels - productivity will be kept high and solution ROI will be significantly higher."
                data-toggle="lightbox"
                data-gallery="gallery8d9f26098f364c9bbf4aba9e68255f6c"
              >
                <img
                  src="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-5.png?h=422&amp;mw=750&amp;w=750&amp;hash=38E42798E7FE5657257AFDA296E6E27A"
                  className="img-responsive"
                  alt="Dependencies in Habitat"
                  width="750"
                  height="422"
                  DisableWebEdit="False"
                />
              </a>
            </div>
          </div>
        </div>
        <div className="block-grid-item">
          <div className="thumbnail mosaic mosaic-circle lightbox-item lightbox-image">
            <div className="mosaic-overlay mosaic-overlay-no-pointer">
              <span className="fa fa-search-plus icon-lg"></span>
            </div>
            <div className="mosaic-backdrop">
              <a
                href="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-6.png?thn=0&amp;w=1200&amp;hash=D74675DA5220454E2AB3706F4142879F"
                data-type="image"
                data-title="Layering makes way for modularity"
                data-footer="Getting&#160;a modular architecture right and harvesting the wins of that relies on having a methodology where dependencies and coupling is controlled."
                data-toggle="lightbox"
                data-gallery="gallery8d9f26098f364c9bbf4aba9e68255f6c"
              >
                <img
                  src="/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-6.png?h=422&amp;mw=750&amp;w=750&amp;hash=2C288116DC3C5F4A81E10CA77B7187BC"
                  className="img-responsive"
                  alt="Dependencies in Habitat"
                  width="750"
                  height="422"
                  DisableWebEdit="False"
                />
              </a>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default MediaGallery;
