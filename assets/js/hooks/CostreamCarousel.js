
export default {
    mounted() {
        let thisElement = this.el;
        let shadowRootElement = document.getElementById('costream-panel');
        let prevButtonElementSelector = thisElement.dataset.prevButton;
        let nextButtonElementSelector = thisElement.dataset.nextButton;
        let prevImageElement = shadowRootElement.shadowRoot.querySelector(".previousCostreamButtonImage");
        let prevButtonElement = shadowRootElement.shadowRoot.querySelector(prevButtonElementSelector);
        let nextImageElement = shadowRootElement.shadowRoot.querySelector(".nextCostreamButtonImage");
        let nextButtonElement = shadowRootElement.shadowRoot.querySelector(nextButtonElementSelector);

        let allElementsArray = Array.from(shadowRootElement.shadowRoot.querySelectorAll('[class *= "visible-slot-"'));
        allElementsArray = allElementsArray.concat(Array.from(shadowRootElement.shadowRoot.querySelectorAll('[class *= "hidden-slot-"')));
        let currentSlot = 0;
        let timeoutId = 0;

        setButtonBackgrounds(allElementsArray[allElementsArray.length - 1], allElementsArray[currentSlot + 1]);

        prevButtonElement.addEventListener("click", (event) => {
            let visibleSlot = currentSlot;
            currentSlot--;
            if(currentSlot < 0) {
                currentSlot = allElementsArray.length - 1;
            }
            swapClassesAndStyles(visibleSlot, currentSlot);            
            swapButtonBackgrounds(currentSlot);
            triggerChannelName(allElementsArray[currentSlot]);            
        });

        nextButtonElement.addEventListener("click", (event) => {
            let visibleSlot = currentSlot;
            currentSlot++;
            if(currentSlot > allElementsArray.length - 1) {
                currentSlot = 0;
            }
            swapClassesAndStyles(visibleSlot, currentSlot);
            swapButtonBackgrounds(currentSlot);
            triggerChannelName(allElementsArray[currentSlot]);
        });

        function swapClassesAndStyles(fromSlot, toSlot) {
            let fromClasses = allElementsArray[fromSlot].className;
            let fromStyle = allElementsArray[fromSlot].style.cssText;
            let toClasses = allElementsArray[toSlot].className;
            let toStyle = allElementsArray[toSlot].style.cssText;
            allElementsArray[toSlot].className = fromClasses;
            allElementsArray[toSlot].style = fromStyle;
            allElementsArray[fromSlot].className = toClasses;
            allElementsArray[fromSlot].style = toStyle;
        }

        function showChannelName(slot) {
            slot.classList.add('active');
        }

        function hideChannelName(slot) {
            slot.classList.remove('active');
        }

        function triggerChannelName(slot) {
            if(timeoutId != 0) {
                clearTimeout(timeoutId);
                hideChannelName(slot);
            }
            showChannelName(slot);
            timeoutId = setTimeout(hideChannelName, 2000, slot);
        }

        function setButtonBackgrounds(prevSlot, nextSlot) {
            let prevElementUrl = prevSlot.querySelector('img').getAttribute('src');
            prevImageElement.src = prevElementUrl;
            let nextElementUrl = nextSlot.querySelector('img').getAttribute('src');
            nextImageElement.src = nextElementUrl;    
        }

        function swapButtonBackgrounds(currentSlotNumber) {
            let prevSlot = currentSlotNumber - 1;
            if(prevSlot < 0) {
                prevSlot = allElementsArray.length - 1;
            }
            let nextSlot = currentSlotNumber + 1;
            if(nextSlot > allElementsArray.length - 1) {
                nextSlot = 0;
            }
            setButtonBackgrounds(allElementsArray[prevSlot], allElementsArray[nextSlot]);
        }
    },
    updated() {
        this.mounted();
    }
}