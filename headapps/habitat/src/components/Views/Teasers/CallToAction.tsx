import { Text, Link, ImageField, LinkFieldValue } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface Fields {
  TeaserTitle: { value: string };
  TeaserSummary: { value: string };
  TeaserImage: { value: ImageField };
  TeaserLink: { value: LinkFieldValue };
}

type CalltoActionProps = {
  params: { [key: string]: string };
  fields: Fields;
};

const CalltoAction = (props: CalltoActionProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Call to Action</h3>
      <div
        className="jumbotron text-center bg-media"
        style={{
          backgroundImage: `url('${props.fields.TeaserImage?.value?.src}')`,
        }}
      >
        <span className="label">Want More?</span>
        <h2>
          <Text field={props.fields.TeaserTitle} />
        </h2>
        <p className="">
          <Text field={props.fields.TeaserSummary} />
        </p>
        <Link field={props.fields.TeaserLink} />
      </div>
    </>
  );
};

export default CalltoAction;
