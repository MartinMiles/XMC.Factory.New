import { ComponentParams, ComponentRendering } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const Video = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Media Gallery</h3>

      <div>
        <div className="embed-responsive embed-responsive-16by9">
          <video width="750" height="414" autoplay loop poster="">
            <source src="/-/media/Habitat/Videos/Sitecore-Experience.mp4" type="video/mp4" />
            <img
              src="/-/media/Habitat/Images/Wide/Habitat-071-wide.jpg?h=258&amp;mw=750&amp;w=750&amp;hash=91A44238AA103EFEB20ADDC1A2820DC5"
              className="img-responsive"
              alt="Experience Marketing"
              width="750"
              height="258"
              DisableWebEdit="False"
            />
          </video>
        </div>
      </div>
    </>
  );
};

export default Video;
