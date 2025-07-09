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

const PageHeaderMediaCarousel = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Page Header Carousuel</h3>
      <div
        id="carousela3acf7a2624c4483b85d2de0c451ab6f"
        className="carousel slide"
        data-ride="carousel"
      >
        <ol className="carousel-indicators">
          <li
            data-target="#carousela3acf7a2624c4483b85d2de0c451ab6f"
            data-slide-to="0"
            className="active"
          ></li>
          <li
            data-target="#carousela3acf7a2624c4483b85d2de0c451ab6f"
            data-slide-to="1"
            className=""
          ></li>
          <li
            data-target="#carousela3acf7a2624c4483b85d2de0c451ab6f"
            data-slide-to="2"
            className=""
          ></li>
          <li
            data-target="#carousela3acf7a2624c4483b85d2de0c451ab6f"
            data-slide-to="3"
            className=""
          ></li>
        </ol>
        <div className="carousel-inner" role="listbox">
          <div className="item active">
            <div
              className="jumbotron jumbotron-xl bg-media"
              style={{
                backgroundImage: "url('/-/media/Habitat/Images/Wide/Habitat-004-wide.jpg')"
              }}
            >
              <div className="container">
                <div className="row">
                  <div className="col-md-12">
                    <h1>Simplicity</h1>
                    <p className="lead">A consistent and discoverable architecture</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="item ">
            <div
              className="jumbotron jumbotron-xl bg-media"
              style={{
                backgroundImage: "url('/-/media/Habitat/Images/Wide/Habitat-007-wide.jpg')"
              }}
            >
              <div className="container">
                <div className="row">
                  <div className="col-md-12">
                    <h1>Flexibility</h1>
                    <p className="lead">Change and add quickly and without worry</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="item ">
            <div
              className="jumbotron jumbotron-xl bg-media"
              style={{
                backgroundImage: "url('/-/media/Habitat/Images/Wide/Habitat-001-wide.jpg')"
              }}
            >
              <div className="container">
                <div className="row">
                  <div className="col-md-12">
                    <h1>Extensibility</h1>
                    <p className="lead">
                      Add new features, simply and without a steep learning curve
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="item ">
            <div
              className="jumbotron jumbotron-xl bg-media"
              style={{
                backgroundImage: "url('/-/media/Habitat/Images/Wide/Habitat-071-wide.jpg')",
              }}
            >
              <video autoPlay={true} loop={true} muted={true} className="video-bg">
                <source src="/-/media/Habitat/Videos/Sitecore-Experience.mp4" type="video/mp4" />
              </video>
              <div className="container">
                <div className="row">
                  <div className="col-md-12">
                    <h1>Sitecore Powered!</h1>
                    <p className="lead">Fully Leveraging the power of Sitecore</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <a
          className="left carousel-control"
          href="#carousela3acf7a2624c4483b85d2de0c451ab6f"
          role="button"
          data-slide="prev"
        >
          <span className="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
          <span className="sr-only">Previous</span>
        </a>
        <a
          className="right carousel-control"
          href="#carousela3acf7a2624c4483b85d2de0c451ab6f"
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

export default PageHeaderMediaCarousel;
