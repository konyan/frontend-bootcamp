import type { User } from "@lib/types";
import { formatDate } from "@lib/utils";
import { useUser } from "@hooks/useUser";

const displayUser = (user: User): string => {
  return `${user.name} joined on ${formatDate(user.createdAt)}`;
};

export { displayUser };
