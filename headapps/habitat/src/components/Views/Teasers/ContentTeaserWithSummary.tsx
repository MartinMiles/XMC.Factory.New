import { ImageField, LinkFieldValue, Link, Text } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface Fields {
  TeaserTitle: { value: string };
  TeaserSummary: { value: string };
  TeaserImage: { value: ImageField };
  TeaserLink: { value: LinkFieldValue };
}

type ContentTeaserwithSummaryProps = {
  params: { [key: string]: string };
  fields: Fields;
};

const ContentTeaserwithSummary = (props: ContentTeaserwithSummaryProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Content Teaser with Summary</h3>
      <div className="well ">
        <h4>
          <Text field={props.fields.TeaserTitle} />
        </h4>
        <Text field={props.fields.TeaserSummary} />
        <Link field={props.fields.TeaserLink} />
      </div>
    </>
  );
};

export default ContentTeaserwithSummary;
