import Component from "@glimmer/component";

export interface ShippingLabelProps {
  recipient: string;
  street: string;
  city: string;
  postcode: string;
}

export interface ShippingLabelSignature {
  Args: ShippingLabelProps;
  Element: HTMLElementTagNameMap["article"];
}

export default class ShippingLabel extends Component<ShippingLabelSignature> {
  get value1() {
    return this.args.city + "  " + this.args.postcode;
  }

  <template><article
      class="shipping-label"
      aria-label="Shipping label"
      ...attributes
    ><p><strong>To:</strong> {{@recipient}}</p><p><span class="shipping-label-city">{{@city}}</span> <span
      class="shipping-label-postcode"
    >{{@postcode}}</span> <span class="shipping-label-country">United Kingdom</span></p><p>  Handle with care </p><pre>{{@recipient}}&#10;{{@street}}&#10;{{this.value1}}</pre><pre>Parcel:	1 of 2
Weight:	2.5 kg</pre><p>Sent by <em>Unframework Ltd</em>, on two
lines.</p></article></template>
}
