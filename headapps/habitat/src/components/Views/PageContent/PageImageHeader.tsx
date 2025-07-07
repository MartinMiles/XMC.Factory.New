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

const PageImageHeader = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Page Image Header</h3>
      <header
        className="page-header bg-media bg-parallax"
        style={{
          backgroundImage:
            "url('/-/media/Habitat/Images/Square/Habitat-043-square.jpg?h=1080&w=1080&hash=A168DE77339B7C25A641DC51BED010E8')",
        }}
      >
        <Placeholder name="page-header" rendering={props.rendering} />
      </header>
    </>
  );
};

export default PageImageHeader;
