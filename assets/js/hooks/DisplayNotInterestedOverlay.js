export default {
    mounted() {
        this.handleEvent("hideNotInterested", params => {
            console.log('hide id: ' + params.id);
        });
    }
}