import { ComponentParams, ComponentRendering } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const MediaCarousel = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Media Carousel</h3>

      <div
        id="carousel01f0ee8c486e4bb38885745b3dba07e1"
        className="carousel slide"
        data-ride="carousel"
      >
        <ol className="carousel-indicators">
          <li
            data-target="#carousel01f0ee8c486e4bb38885745b3dba07e1"
            data-slide-to="0"
            className="active"
          ></li>
          <li
            data-target="#carousel01f0ee8c486e4bb38885745b3dba07e1"
            data-slide-to="1"
            className=""
          ></li>
          <li
            data-target="#carousel01f0ee8c486e4bb38885745b3dba07e1"
            data-slide-to="2"
            className=""
          ></li>
          <li
            data-target="#carousel01f0ee8c486e4bb38885745b3dba07e1"
            data-slide-to="3"
            className=""
          ></li>
          <li
            data-target="#carousel01f0ee8c486e4bb38885745b3dba07e1"
            data-slide-to="4"
            className=""
          ></li>
          <li
            data-target="#carousel01f0ee8c486e4bb38885745b3dba07e1"
            data-slide-to="5"
            className=""
          ></li>
        </ol>

        <div className="carousel-inner" role="listbox">
          <div className="item active">
            <div
              className="jumbotron bg-media"
              style={{
                backgroundImage: `url(/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-1.png)`,
              }}
            >
              <h3>Building a Sitecore Solution is Easy!</h3>
              <div className="lead">
                <p>
                  Taking the first steps in building a Sitecore solution is often quite rapid. You
                  can be very productive and cover a great deal of functionality in a short sprint
                </p>
              </div>
            </div>
          </div>
          <div className="item ">
            <div
              className="jumbotron bg-media"
              style={{
                backgroundImage: `url(/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-2.png)`,
              }}
            >
              <h3>Coupling between features and functionality can make life harder.</h3>
              <div className="lead">
                <p>
                  Once the solution scope is expanding, dependencies and coupling between features
                  and functionalities can make productivity slower.
                </p>
              </div>
            </div>
          </div>
          <div className="item ">
            <div
              className="jumbotron bg-media"
              style={{
                backgroundImage: `url(/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-3.png)`,
              }}
            >
              <h3>Wrong architecture can grind productivity to a halt.</h3>
              <div className="lead">
                If dependencies and coupling in not constantly monitored and conventions and
                principles are kept in place, over time the productivity and thereby long term
                business value will suffer.
              </div>
            </div>
          </div>
          <div className="item ">
            <div
              className="jumbotron bg-media"
              style={{
                backgroundImage: `url(/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-4.png)`,
              }}
            >
              <h3>Correct layering and dependency control</h3>
              <div className="lead">
                With a layered approach, where dependencies are tightly controlled using technical
                design principles and patterns. The coupling between modules and functionalities can
                be reduced significantly.
              </div>
            </div>
          </div>
          <div className="item ">
            <div
              className="jumbotron bg-media"
              style={{
                backgroundImage: `url(/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-5.png)`,
              }}
            >
              <h3>Low coupling means higher productivity</h3>
              <div className="lead">
                With fewer dependencies and tighter controlled coupling - both on the micro and
                macro architecture levels - productivity will be kept high and solution ROI will be
                significantly higher.
              </div>
            </div>
          </div>
          <div className="item ">
            <div
              className="jumbotron bg-media"
              style={{
                backgroundImage: `url(/-/media/Habitat/Images/Content/Dependencies/Habitat-Dependencies-6.png)`,
              }}
            >
              <h3>Layering makes way for modularity</h3>
              <div className="lead">
                Getting a modular architecture right and harvesting the wins of that relies on
                having a methodology where dependencies and coupling is controlled.
              </div>
            </div>
          </div>
        </div>

        <a
          className="left carousel-control"
          href="#carousel01f0ee8c486e4bb38885745b3dba07e1"
          role="button"
          data-slide="prev"
        >
          <span className="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
          <span className="sr-only">Previous</span>
        </a>
        <a
          className="right carousel-control"
          href="#carousel01f0ee8c486e4bb38885745b3dba07e1"
          role="button"
          data-slide="next"
        >
          <span className="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
          <span className="sr-only">Next</span>
        </a>
      </div>
    </>
  );
};

export default MediaCarousel;
