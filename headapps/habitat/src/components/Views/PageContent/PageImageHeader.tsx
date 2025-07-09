import {
  ComponentParams,
  ComponentRendering,
  ImageField,
  Placeholder,
  useSitecoreContext,
} from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

interface PageImageHeaderProps extends ComponentProps {
  fields: {
    Image: { value: ImageField };
  };
}

export const Default: React.FC<PageImageHeaderProps> = (props): JSX.Element => {
  const { sitecoreContext } = useSitecoreContext();
  const imageField = props?.fields?.Image || sitecoreContext?.route?.fields?.Image;

  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Page Image Header</h3>
      <header
        className="page-header bg-media bg-parallax"
        style={{
          backgroundImage: `url(${imageField.value?.src})`,
        }}
      >
        <Placeholder name="page-header" rendering={props.rendering} />
      </header>
    </>
  );
};
