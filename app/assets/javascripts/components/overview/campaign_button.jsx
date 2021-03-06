import React from 'react';
import PopoverButton from '../high_order/popover_button.jsx';
import CampaignStore from '../../stores/campaign_store.js';

const campaignIsNew = campaign => CampaignStore.getFiltered({ title: campaign }).length === 0;

const campaigns = (props, remove) =>
  props.campaigns.map(campaign => {
    let removeButton = (
      <button className="button border plus" onClick={remove.bind(null, campaign.id)}>-</button>
    );
    return (
      <tr key={`${campaign.id}_campaign`}>
        <td>{campaign.title}{removeButton}</td>
      </tr>
    );
  })
;

campaigns.propTypes = {
  campaigns: React.PropTypes.array
};

export default PopoverButton('campaign', 'title', CampaignStore, campaignIsNew, campaigns, true);
