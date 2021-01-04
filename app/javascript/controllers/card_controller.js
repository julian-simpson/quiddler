import ApplicationController from './application_controller'
import Sortable from "sortablejs"

export default class extends ApplicationController {

  connect() {
    super.connect()
    console.log("CONNECTING TO CARD CONTROLLER JS")
    let currentPlayerCards = document.getElementById('current-player-hand');
    this.sortable = Sortable.create(currentPlayerCards, {
      group: 'shared',
      animation: 0,
      onEnd: this.drop.bind(this)
    })
    let discardLanding = document.getElementById('discard-landing');
    this.sortable = Sortable.create(discardLanding, {
      sort: false,
      group: 'shared',
      animation: 0,
      swapThreshold: 0,
      filter: '.not-draggable',
      onEnd: this.drop.bind(this),
      onMove: this.move.bind(this),
    })

  }
  drop(event) {
    if (event.from.id == "current-player-hand" && event.to.id == "discard-landing"){
      this.stimulate('GameReflex#discard', event.item)
    } else if (event.from.id == "discard-landing" && event.to.id == "current-player-hand"){
      event.item.classList.add('current-player-card');
      let sorted_card_ids = this.get_sorted_card_ids()
      event.to.dataset.cards = JSON.stringify(sorted_card_ids)
      this.stimulate('GameReflex#drag_from_discard_pile', event.to)
    } else if (event.from.id == "current-player-hand" && event.to.id == "current-player-hand"){
      let sorted_card_ids = this.get_sorted_card_ids()
      event.to.dataset.cards = JSON.stringify(sorted_card_ids)
      this.stimulate('GameReflex#sort_hand', event.to)
    }
  }

  move(event){
    if (event.dragged.classList.contains("not-draggable")){
      return false
    }
  }

  get_sorted_card_ids () {
    let cardElements = document.getElementsByClassName('current-player-card')
    let sorted_card_ids= Array.from(cardElements).map((card) => {
      return card.dataset.cardId
    })
    // console.log(sorted_card_ids)
    return sorted_card_ids
  }
}
