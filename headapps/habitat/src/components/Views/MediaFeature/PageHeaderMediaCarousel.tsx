import { Text, ImageField } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface Field {
  url: string;
  fields: {
    MediaImage: {
      value: {
        src: string;
      };
    };
    MediaVideoLink: {
      value: {
        src: string;
      };
    };
    MediaThumbnail: { value: ImageField };
    MediaTitle: { value: string };
    MediaDescription: { value: string };
  };
}

interface ReferencedItem {
  jsonValue: Field[];
}

type PageHeaderMediaCarouselProps = {
  params: { [key: string]: string };
  fields: {
    data: {
      datasource: {
        fields: ReferencedItem[];
      };
    };
  };
};

const PageHeaderMediaCarousel = (props: PageHeaderMediaCarouselProps): JSX.Element => {
  function isNonEmptyArray(val) {
    return Array.isArray(val) && val.length > 0;
  }
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Page Header Carousuel</h3>
      <div
        id="carousela3acf7a2624c4483b85d2de0c451ab6f"
        className="carousel slide"
        data-ride="carousel"
      >
        {props.fields.data.datasource.fields.map(
          (ref, idx) =>
            isNonEmptyArray(ref?.jsonValue) && (
              <ol key={idx} className="carousel-indicators">
                {ref.jsonValue.map((item, index) => (
                  <li
                    key={index}
                    data-target="#carousel{index}"
                    data-slide-to={index}
                    className={index === 0 ? 'active' : ''}
                  ></li>
                ))}
              </ol>
            )
        )}
        {props.fields.data.datasource.fields.map(
          (ref, idx) =>
            isNonEmptyArray(ref?.jsonValue) && (
              <div key={idx} className="carousel-inner" role="listbox">
                {ref.jsonValue.map((item, index) => (
                  <div key={index} className="item active">
                    <div
                      className="jumbotron jumbotron-xl bg-media"
                      style={{
                        backgroundImage: `url('${item.fields.MediaThumbnail.value.src}')`,
                      }}
                    >
                      {item.fields.MediaVideoLink &&
                        item.fields.MediaVideoLink.value &&
                        (() => (
                          <video autoPlay={true} loop={true} muted={true} className="video-bg">
                            <source
                              src="https://xmcloudcm.localhost/-/media/Habitat/Videos/Sitecore-Experience.mp4"
                              type="video/mp4"
                            ></source>
                          </video>
                        ))()}
                      <div className="container">
                        <div className="row">
                          <div className="col-md-12">
                            <h1>
                              <Text field={item.fields.MediaTitle} />
                            </h1>
                            <p className="lead">
                              <Text field={item.fields.MediaDescription} />
                            </p>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )
        )}

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
