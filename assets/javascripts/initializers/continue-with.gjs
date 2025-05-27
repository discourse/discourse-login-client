import { withPluginApi } from "discourse/lib/plugin-api";
import DButton from "discourse/components/d-button";

export default {
  initialize(container) {
    const { isOnlyOneExternalLoginMethod, externalLoginMethods, singleExternalLogin } = container.lookup("service:login");
    const onlyDiscourseId = isOnlyOneExternalLoginMethod && externalLoginMethods[0].name === "discourse_login";

    withPluginApi(({ headerButtons }) => {
      if (onlyDiscourseId) {
        const currentUser = container.lookup("service:current-user");

        headerButtons.delete("auth");
        headerButtons.add("continue-with", <template>
          {{#unless currentUser}}
            <DButton
              class="continue-with-discourse btn-primary"
              @icon="fab-discourse"
              @label="discourse_login.continue_with"
              @action={{singleExternalLogin}}
            />
          {{/unless}}
        </template>);
      }
    });
  }
}