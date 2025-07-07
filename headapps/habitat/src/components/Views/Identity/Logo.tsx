import { ImageField, Image } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface Fields {
  Logo: { value: ImageField };
}

type LogoProps = {
  params: { [key: string]: string };
  fields: Fields;
};

const Logo = (props: LogoProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Logo</h3>
      <h4>{props.params.RenderingIdentifier}</h4>
      <a className="navbar-brand " href="http://habitat.dev.local/en">
        <span className="logo">
          <Image field={props.fields.Logo} />
        </span>
      </a>
    </>
  );
};

export default Logo;
