const DatePicker = {
  mounted() {
    let inputElement = this.el.querySelectorAll("input");

    inputElement.forEach((input) =>
      input.addEventListener("focus", () => {
        if (!this.isOpen) {
          this.isOpen = true;
          this.pushEventTo("#date-picker", "open_datepicker", {});
        }
      })
    );
    this.el.addEventListener("click", () => {
      if (!this.isOpen) {
        this.isOpen = true;
        this.pushEventTo("#date-picker", "open_datepicker", {});
      }
    });
    this.handleOutsideClick = (event) => {
      if (!this.el.contains(event.target) && this.isOpen) {
        this.pushEventTo("#date-picker", "close_datepicker", {});
        this.isOpen = false;
      }
    };

    document.addEventListener("click", this.handleOutsideClick);
  },

  destroyed() {
    document.removeEventListener("click", this.handleOutsideClick);
  },
};

export default DatePicker;
