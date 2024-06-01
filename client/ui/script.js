/*--------------------------------------------------------
----       For Support - discord.gg/threeamigos       ----
---- Do not edit if you do not know what you"re doing ----
--------------------------------------------------------*/

const seatbeltUI = Vue.createApp({
  data() {
    return {
      showSeatbelt: true,
    };
  },
  destroyed() {
    window.removeEventListener("message", this.listener);
  },
  mounted() {
    this.listener = window.addEventListener("message", (event) => {
      if (event.data.action === "updateSeatbelt") {
        this.updateSeatbelt(event.data);
      }
    });
  },
  methods: {
    updateSeatbelt(data) {
      this.seatbelt = data.seatbelt;
      if (this.seatbelt || !this.showSeatbelt) {
        $(".seatbelt").fadeOut();
      } else {
        $(".seatbelt").fadeIn();
      }
    },
  },
}).mount("#vehhud-container");