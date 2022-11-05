use crate::counter::CounterModel;
use yew::prelude::*;

#[function_component(App)]
pub fn app() -> Html {
    html! {
        <div class={classes!("container", "is-flex", "is-justify-content-center", "is-flex-direction-column", "is-align-items-center")}>
            <img src="yew_logo.png" style="width: 128px; height: 128px"/>
            <p class={classes!("has-text-primary", "is-size-4", "has-text-weight-bold")}>
                {"Welcome to Yew"}
            </p>
            <div>
                <span>{"To get started, edit "}</span>
                <span class={classes!("is-family-code", "has-background-grey-lighter")}>{"src/main.rs"}</span>
                <span>{" and save to reload."}</span>
            </div>
            <CounterModel/>
        </div>
    }
}
