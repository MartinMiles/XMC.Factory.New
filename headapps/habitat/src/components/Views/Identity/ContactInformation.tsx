import { Link, LinkFieldValue, Text } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface Fields {
  OrganisationName: { value: string };
  OrganisationAddress: { value: string };
  OrganisationPhone: { value: string };
  OrganisationEmail: { value: LinkFieldValue };
}

type ContactInformationProps = {
  params: { [key: string]: string };
  fields: Fields;
};

function parseSitecoreLinkXmlToJssField(linkValue: string | LinkFieldValue) {
  if (!linkValue) return null;
  const textMatch = linkValue.match(/text='([^']*)'/);
  const hrefMatch = linkValue.match(/url='([^']*)'/);
  const titleMatch = linkValue.match(/title='([^']*)'/);
  const linktypeMatch = linkValue.match(/linktype='([^']*)'/);

  return {
    value: {
      href: hrefMatch ? hrefMatch[1] : '',
      text: textMatch ? textMatch[1] : '',
      title: titleMatch ? titleMatch[1] : '',
      linktype: linktypeMatch ? linktypeMatch[1] : ''
    }
  };
}

const ContactInformation = (props: ContactInformationProps): JSX.Element => {

  const parsedField = parseSitecoreLinkXmlToJssField(props.fields.OrganisationEmail.value);
  if (!parsedField) return <></>;

  return (
    <>
      <h3 style={{ color: 'red' }}>Contact Information</h3>
      <div className="well ">
        <h4>Contact information</h4>
        <address>
          <p>
            <strong>
              <Text field={props.fields.OrganisationName} />
            </strong>
            <br />
            <Text field={props.fields.OrganisationAddress} />
          </p>
          <p>
            <i className="fa fa-phone"></i> <Text field={props.fields.OrganisationPhone} /> <br />
            <i className="fa fa-envelope"> </i>
            <Link field={parsedField} className="your-class" />;
          </p>
        </address>
      </div>
    </>
  );
};

export default ContactInformation;
