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

const ChildPageList = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3>Child Page List</h3>
      <div className="block-grid-md-2 block-grid-sm-1 block-grid-xs-1">
        <div className="block-grid-item">
          <div>

          {/* <Placeholder name="col-huge" rendering={props.rendering} /> */}


            <div className="thumbnail">
              <a href="http://habitat.dev.local/en/About-Habitat/Introduction">
                <img
                  src="/-/media/Habitat/Images/Square/Habitat-067-square.jpg?h=500&amp;mw=500&amp;w=500&amp;hash=A070A749EEDBB0F49F3D25AD837C9BBC"
                  className="img-responsive"
                  alt=""
                  width="500"
                  height="500"
                  DisableWebEdit="False"
                />
              </a>
              <div className="caption">
                <h3 className="teaser-heading">Introduction to Habitat</h3>
                <p>
                  <p>
                    Sitecore Habitat is a range of sites demonstrating the capabilities of the
                    Sitecore Experience Platform.{' '}
                  </p>
                  <p>
                    The solution is built on the Sitecore Helix guidelines, which&nbsp;
                    <span>focuses on increasing productivity and quality in Sitecore projects</span>
                    .
                  </p>
                </p>
                <a
                  href="http://habitat.dev.local/en/About-Habitat/Introduction"
                  className="btn btn-default"
                >
                  Read more
                </a>
              </div>
            </div>
          </div>
        </div>
        <div className="block-grid-item">
          <div>
            <div className="thumbnail">
              <a href="http://habitat.dev.local/en/About-Habitat/Getting-Started">
                <img
                  src="/-/media/Habitat/Images/Square/Habitat-022-square.jpg?h=500&amp;mw=500&amp;w=500&amp;hash=FF6CADD12E5A79A37835E89D88B034A5"
                  className="img-responsive"
                  alt=""
                  width="500"
                  height="500"
                  DisableWebEdit="False"
                />
              </a>
              <div className="caption">
                <h3 className="teaser-heading">Getting Started</h3>
                <p>
                  <p>
                    Sitecore Helix a defined methodology with conventions and practises - Habitat is
                    an example implementation available for your understanding.
                  </p>
                </p>
                <a
                  href="http://habitat.dev.local/en/About-Habitat/Getting-Started"
                  className="btn btn-default"
                >
                  Read more
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default ChildPageList;
